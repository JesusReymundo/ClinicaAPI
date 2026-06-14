using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Pacientes")]
public class Paciente
{
    [Key]
    public int IdPaciente { get; set; }
    public int IdUsuario { get; set; }
    public int IdTipoAsegurado { get; set; }
    public int? IdEmpresa { get; set; }
    [MaxLength(50)]
    public string? NumeroSeguro { get; set; }
    [MaxLength(5)]
    public string? GrupoSanguineo { get; set; }
    [MaxLength(500)]
    public string? Alergias { get; set; }
    public DateTime FechaCreacion { get; set; } = DateTime.Now;

    [ForeignKey("IdUsuario")]
    public Usuario? Usuario { get; set; }
    [ForeignKey("IdTipoAsegurado")]
    public TipoAsegurado? TipoAsegurado { get; set; }
    [ForeignKey("IdEmpresa")]
    public Empresa? Empresa { get; set; }
}
