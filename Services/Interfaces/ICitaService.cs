using ClinicaAPI.DTOs;
using ClinicaAPI.Models;

namespace ClinicaAPI.Services.Interfaces;

public interface ICitaService
{
    IEnumerable<CitaResponseDto> ObtenerTodas();
    CitaResponseDto ObtenerPorId(int id);
    IEnumerable<CitaResponseDto> ObtenerPorPaciente(int pacienteId);
    IEnumerable<CitaResponseDto> ObtenerPorMedico(int medicoId);
    IEnumerable<CitaResponseDto> ObtenerPorEstado(EstadoCita estado);
    CitaResponseDto Crear(CitaCreateDto dto);
    CitaResponseDto Actualizar(int id, CitaUpdateDto dto);
    CitaResponseDto Cancelar(int id);
    CitaResponseDto Anular(int id);
    void Eliminar(int id);
}
