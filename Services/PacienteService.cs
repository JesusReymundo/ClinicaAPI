using ClinicaAPI.DTOs;
using ClinicaAPI.Exceptions;
using ClinicaAPI.Models;
using ClinicaAPI.Services.Interfaces;

namespace ClinicaAPI.Services;

public class PacienteService : IPacienteService
{
    private readonly List<Paciente> _pacientes = new();
    private int _nextId = 1;

    public PacienteService()
    {
        _pacientes.Add(new Paciente { Id = _nextId++, Nombre = "Juan", Apellido = "Pérez", Dni = "12345678", Telefono = "987654321", Email = "juan@email.com", FechaNacimiento = new DateTime(1990, 5, 15) });
        _pacientes.Add(new Paciente { Id = _nextId++, Nombre = "María", Apellido = "García", Dni = "87654321", Telefono = "912345678", Email = "maria@email.com", FechaNacimiento = new DateTime(1985, 8, 22) });
    }

    public IEnumerable<PacienteResponseDto> ObtenerTodos() =>
        _pacientes.Select(MapToDto);

    public PacienteResponseDto ObtenerPorId(int id)
    {
        var paciente = _pacientes.FirstOrDefault(p => p.Id == id)
            ?? throw new NotFoundException($"Paciente con ID {id} no encontrado");
        return MapToDto(paciente);
    }

    public PacienteResponseDto Crear(PacienteCreateDto dto)
    {
        if (_pacientes.Any(p => p.Dni == dto.Dni))
            throw new BusinessException($"Ya existe un paciente con el DNI {dto.Dni}");

        var paciente = new Paciente
        {
            Id = _nextId++,
            Nombre = dto.Nombre,
            Apellido = dto.Apellido,
            Dni = dto.Dni,
            Telefono = dto.Telefono,
            Email = dto.Email,
            FechaNacimiento = dto.FechaNacimiento
        };

        _pacientes.Add(paciente);
        return MapToDto(paciente);
    }

    public PacienteResponseDto Actualizar(int id, PacienteUpdateDto dto)
    {
        var paciente = _pacientes.FirstOrDefault(p => p.Id == id)
            ?? throw new NotFoundException($"Paciente con ID {id} no encontrado");

        if (_pacientes.Any(p => p.Dni == dto.Dni && p.Id != id))
            throw new BusinessException($"Ya existe otro paciente con el DNI {dto.Dni}");

        paciente.Nombre = dto.Nombre;
        paciente.Apellido = dto.Apellido;
        paciente.Dni = dto.Dni;
        paciente.Telefono = dto.Telefono;
        paciente.Email = dto.Email;
        paciente.FechaNacimiento = dto.FechaNacimiento;

        return MapToDto(paciente);
    }

    public void Eliminar(int id)
    {
        var paciente = _pacientes.FirstOrDefault(p => p.Id == id)
            ?? throw new NotFoundException($"Paciente con ID {id} no encontrado");
        _pacientes.Remove(paciente);
    }

    private static PacienteResponseDto MapToDto(Paciente p) => new()
    {
        Id = p.Id,
        Nombre = p.Nombre,
        Apellido = p.Apellido,
        Dni = p.Dni,
        Telefono = p.Telefono,
        Email = p.Email,
        FechaNacimiento = p.FechaNacimiento
    };
}
